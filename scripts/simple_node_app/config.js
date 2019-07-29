var config = {}

config.host = process.env.HOST || "https://cosacc.documents.azure.com:443/";
config.authKey = process.env.AUTH_KEY || "cXUaxo2nHCAlh8T8yK7dCjOulbp4NZzL8wkx5TxLyhr4VNXY95uSEbrYWTZNbRENbE5d9uHCNrjf4v7HSHygHA==";
config.databaseId = "ToDoList";
config.collectionId = "Items";

module.exports = config;