﻿using Magenic.MaqsFramework.BaseMongoDBTest;
using MongoDB.Bson;
using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Magenic.MaqsFramework.BaseMongoDBTest
{
    public class MongoDBCollectionWrapper<T>
    {
        /// <summary>
        /// stores the mongo Collection
        /// </summary>

        public IMongoClient client;

        public IMongoDatabase database;

        public IMongoCollection<T> collection;

        public MongoDBCollectionWrapper(string connectionString, string databaseString, string collectionString){
            this.client = new MongoClient(new MongoUrl(connectionString));
            this.database = client.GetDatabase(databaseString);
            this.collection = database.GetCollection<T>(collectionString);
        }

        public MongoDBCollectionWrapper(string collectionString){
            this.client = new MongoClient(new MongoUrl(MongoDBConfig.GetConnectionString()));
            this.database = client.GetDatabase(MongoDBConfig.GetDatabaseString());
            this.collection = database.GetCollection<T>(collectionString);
        }

        public MongoDBCollectionWrapper() {
            this.client = new MongoClient(new MongoUrl(MongoDBConfig.GetConnectionString()));
            this.database = client.GetDatabase(MongoDBConfig.GetDatabaseString());
            this.collection = database.GetCollection<T>(MongoDBConfig.GetCollectionString());
        }

        /// <summary>
        /// Returns the MongoDB database 
        /// </summary>
        /// <returns>accessed mongoDB database from the client</returns>
        public IMongoClient ReturnMongoDBClient()
        {
            return this.client;
        }

        /// <summary>
        /// Returns the MongoDB database 
        /// </summary>
        /// <returns>accessed mongoDB database from the client</returns>
        public IMongoDatabase ReturnMongoDBDatabase()
        {
            return this.database;
        }

        /// <summary>
        /// Returns the MongoDB database 
        /// </summary>
        /// <returns>accessed mongoDB database from the client</returns>
        public IMongoCollection<T> ReturnMongoDBCollection()
        {
            return this.collection;
        }

        /// <summary> 
        /// Default client connection setup - Override this function to create your own connection
        /// </summary>
        /// <param name="connectionString">The mongo database client name string</param>
        /// <returns>The mongo database client</returns>
        protected virtual IMongoClient SetupMongoDBClient(string connectionString)
        {
            MongoUrl mongoURL = new MongoUrl(connectionString);
            return new MongoClient(mongoURL);
        }

        /// <summary>
        /// returns a database from the mongo client
        /// </summary>
        /// <param name="databaseName">the mongo database name string</param>
        /// <returns>The mongo database client</returns>
        protected virtual IMongoDatabase SetUpMongoDBDatabase(string databaseName)
        {
            return this.client.GetDatabase(databaseName);
        }


        public List<T> ListAllCollectionItems() {
            return this.collection.Find<T>(_ => true).ToList();
        }

        public bool IsCollectionEmpty()
        {
            return !this.collection.Find<T>(_ => true).Any();
        }

        public int CountAllItemsInCollection()
        {
            return int.Parse(this.collection.Find<T>(_ => true).Count().ToString());
        }

        public int CountItemsInCollectionWithRecord(string key, string value) {
            return QueryAndReturnList(key, value).Count;
        }

        public List<T> QueryAndReturnList(string key, string value) {
            var filter = Builders<T>.Filter.Eq(key, value);
            var retValue = this.collection.Find(filter).ToList();
            return retValue;
        }

        public T QueryAndReturnFirst(string key, string value)
        {
            var filter = Builders<T>.Filter.Eq(key, value);
            var retValue = this.collection.Find(filter).ToList()[0];
            return retValue;
        }

        public List<T> FindListWithKey(string key) {
            var filter = Builders<T>.Filter.Exists(key);
            var retValue = this.collection.Find(filter).ToList();
            return retValue;
        }

        public T FindFirstItemWithKey(string key) {
            var filter = Builders<T>.Filter.Exists(key);
            return this.collection.Find(filter).ToList().First();
        }
    }
}
