import json
import boto3
import time
from botocore.exceptions import ClientError

# Exponential backoff configuration
MAX_RETRIES = 3
BASE_DELAY = 0.1  # 100ms

def handle_throttling(func):
    """Decorator for handling throttling with exponential backoff"""
    def wrapper(*args, **kwargs):
        retries = 0
        while retries < MAX_RETRIES:
            try:
                return func(*args, **kwargs)
            except ClientError as e:
                if e.response['Error']['Code'] == 'ProvisionedThroughputExceededException':
                    if retries == MAX_RETRIES - 1:
                        raise
                    sleep_time = (2 ** retries) * BASE_DELAY
                    print(f"Request throttled. Retrying in {sleep_time} seconds...")
                    time.sleep(sleep_time)
                    retries += 1
                else:
                    raise
    return wrapper

@handle_throttling
def get_item_with_retries(client, table_name, key, consistent_read=False):
    """GetItem with retries and consistency control"""
    try:
        return client.get_item(
            TableName=table_name,
            Key=key,
            ConsistentRead=consistent_read
        )
    except ClientError as e:
        error_code = e.response['Error']['Code']
        if error_code == 'ResourceNotFoundException':
            print(f"Table {table_name} not found")
        elif error_code == 'ValidationException':
            print("Invalid parameter value")
        raise

@handle_throttling
def update_item_with_retries(client, table_name, key, update_expression, 
                           expression_attribute_names, expression_attribute_values,
                           condition_expression=None):
    """UpdateItem with retries and concurrency control"""
    try:
        params = {
            'TableName': table_name,
            'Key': key,
            'UpdateExpression': update_expression,
            'ExpressionAttributeNames': expression_attribute_names,
            'ExpressionAttributeValues': expression_attribute_values,
            'ReturnValues': 'ALL_NEW'
        }
        
        # Add condition expression for concurrent updates
        params['ConditionExpression'] = 'attribute_not_exists(#attr) OR #attr = :empty'
        params['ExpressionAttributeValues'][':empty'] = {'S': ''}
            
        return client.update_item(**params)
        
    except ClientError as e:
        error_code = e.response['Error']['Code']
        if error_code == 'ConditionalCheckFailedException':
            print("Update failed: Attribute no longer empty")
            raise Exception("This field has been updated by another user. Please check the current value.")
        elif error_code == 'ResourceNotFoundException':
            print(f"Table {table_name} not found")
        raise


def lambda_handler(event, context):
    print(f"Input from agent: {event}")
    user_name = event['parameters'][0]['value']
    
    client = boto3.client('dynamodb')
    table_name = 'checkUpdateBlog-employee-records'
    
    if event['httpMethod'] == 'GET':
        # Initial check for empty values uses eventually consistent reads
        response = get_item_with_retries(
            client,
            table_name,
            {'Name': {'S': user_name}},
            consistent_read=False
        )
        
        print(f"DynamoDB response: {response}")
        
        if 'Item' not in response:
            response_body = {
                'application/json': {
                    'body': json.dumps({
                        'status': 'NOT_FOUND',
                        'message': f"No record found for name: {user_name}"
                    })
                }
            }
        else:
            item = response['Item']
            empty_attributes = []
            
            for attr_name in item:
                if attr_name != 'Name':
                    if attr_name not in item or (
                        'S' in item[attr_name] and not item[attr_name]['S'].strip()
                    ):
                        empty_attributes.append(attr_name)
            
            response_body = {
                'application/json': {
                    'body': json.dumps({
                        'status': 'SUCCESS',
                        'name': user_name,
                        'empty_attributes': empty_attributes,
                        'current_values': {
                            k: (v.get('S') or v.get('N')) 
                            for k, v in item.items() 
                            if k not in empty_attributes
                        }
                    })
                }
            }
            
    elif event['httpMethod'] == 'POST':
        try:
            print("Full request:", json.dumps(event, indent=2))
            request_properties = event['requestBody']['content']['application/json']['properties']
            
            attribute_name = None
            attribute_value = None
            
            for prop in request_properties:
                if prop['name'] == 'attribute_name':
                    attribute_name = prop['value']
                elif prop['name'] == 'attribute_value':
                    attribute_value = prop['value']
            
            print(f"Found values - attribute_name: {attribute_name}, attribute_value: {attribute_value}")
            
            if not attribute_name or not attribute_value:
                raise ValueError("Missing attribute_name or attribute_value")

            # Update with retry handling
            response = update_item_with_retries(
                client,
                table_name,
                {'Name': {'S': user_name}},
                'SET #attr = :val',
                {'#attr': attribute_name},
                {':val': {'S': attribute_value}}
                )

            
            # Verify update with strongly consistent read
            verification = get_item_with_retries(
                client,
                table_name,
                {'Name': {'S': user_name}},
                consistent_read=True
            )
            
            print(f"DynamoDB update response: {response}")
            
            response_body = {
                'application/json': {
                    'body': json.dumps({
                        'status': 'SUCCESS',
                        'message': f"Successfully updated {attribute_name} to {attribute_value} for {user_name}",
                        'updated_values': response['Attributes']
                    })
                }
            }
                
        except Exception as e:
            print(f"Error occurred: {str(e)}")
            print(f"Error type: {type(e)}")
            response_body = {
                'application/json': {
                    'body': json.dumps({
                        'status': 'ERROR',
                        'message': f"Error updating value: {str(e)}"
                    })
                }
            }
    action_response = {
        'actionGroup': event['actionGroup'],
        'apiPath': event['apiPath'],
        'httpMethod': event['httpMethod'],
        'httpStatusCode': 200,
        'responseBody': response_body
    }

    
    return {
        'messageVersion': '1.0',
        'response': action_response,
        'sessionAttributes': event['sessionAttributes'],
        'promptSessionAttributes': event['promptSessionAttributes']
    }
