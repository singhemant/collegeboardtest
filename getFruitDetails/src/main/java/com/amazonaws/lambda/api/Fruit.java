package com.amazonaws.lambda.api;

import java.io.Serializable;

import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBAttribute;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBHashKey;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBTable;

@DynamoDBTable(tableName = "fruits")
public class Fruit implements Serializable {

	private static final long serialVersionUID = -5627101461308045637L;

	@DynamoDBAttribute
	private String shape;

	@DynamoDBAttribute
	private String size;

	@DynamoDBAttribute
	private String color;

	@DynamoDBHashKey
	private String fruitName;

	public Fruit(String shape, String size, String color, String fruitName) {
		super();
		this.shape = shape;
		this.size = size;
		this.color = color;
		this.fruitName = fruitName;
	}

	public Fruit() {}
	
	public String getShape() {
		return shape;
	}

	public void setShape(String shape) {
		this.shape = shape;
	}

	public String getSize() {
		return size;
	}

	public void setSize(String size) {
		this.size = size;
	}

	public String getColor() {
		return color;
	}

	public void setColor(String color) {
		this.color = color;
	}

	public String getFruitName() {
		return fruitName;
	}

	public void setFruitName(String fruitName) {
		this.fruitName = fruitName;
	}

}
