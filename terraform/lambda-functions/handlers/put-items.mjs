import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, PutCommand } from '@aws-sdk/lib-dynamodb';
import { randomUUID } from 'crypto';
const client = new DynamoDBClient({});
const ddbDocClient = DynamoDBDocumentClient.from(client);

// Get the DynamoDB table name from environment variables
const tableName = process.env.TABLE_NAME;

export const putItemHandler = async (event) => {
    console.info('received:', event);

    // Get id and name from the body of the request
    const body = JSON.parse(event.body);
    const email = body.email;
    const name = body.name;
    const color = body.color;
    const price = body.price;
    const product_id = randomUUID()

    var params = {
        TableName: tableName,
        Item: { 'email': email, 'name': name, 'color': color, 'price': price, 'product-id': product_id }
    };

    try {
        const data = await ddbDocClient.send(new PutCommand(params));
        console.log("Success - item added or updated", data);
    } catch (err) {
        console.log("Error", err.stack);
    }

    const response = {
        statusCode: 200,
        headers: {
            'Access-Control-Allow-Headers': 'Content-Type,Authorization,Cache-Control',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
        },
        body: JSON.stringify(body)
    };

    // All log statements are written to CloudWatch
    console.info(`response from: ${event.path} statusCode: ${response.statusCode} body: ${response.body}`);
    return response;
};
