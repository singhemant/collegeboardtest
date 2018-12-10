package com.amazonaws.lambda.api;

import com.amazonaws.services.dynamodbv2.AmazonDynamoDB;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDBClientBuilder;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBMapper;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

public class FruitController implements RequestHandler<Request, Object> {

	@Override
	public Object handleRequest(Request httpRequest, Context context) {
		// TODO Auto-generated method stub
		Fruit fruit = null;
		AmazonDynamoDB client = AmazonDynamoDBClientBuilder.defaultClient();
		DynamoDBMapper mapper = new DynamoDBMapper(client);
		
		switch (httpRequest.getHttpMethod()) {
		case "GET":
				fruit = mapper.load(Fruit.class, httpRequest.getFruitName());
			return fruit;
		case "POST":
			fruit = httpRequest.getFruit();
			mapper.save(fruit);
			return fruit;
		default:
			break;
		}
		return null;
	}
}
