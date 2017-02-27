﻿//--------------------------------------------------
// <copyright file="MongoTestObject.cs" company="Magenic">
//  Copyright 2017 Magenic, All rights Reserved
// </copyright>
// <summary>Holds MongoDB context data</summary>
//--------------------------------------------------
using Magenic.MaqsFramework.BaseTest;
using Magenic.MaqsFramework.Utilities.Logging;
using Magenic.MaqsFramework.Utilities.Performance;

namespace Magenic.MaqsFramework.BaseMongoDBTest
{
    /// <summary>
    /// Mongo test context data
    /// </summary>
    public class MongoTestObject : BaseTestObject
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="MongoTestObject" /> class
        /// </summary>
        /// <param name="mongoConnection">The test's mongo connection</param>
        /// <param name="logger">The test's logger</param>
        /// <param name="softAssert">The test's soft assert</param>
        /// <param name="perfTimerCollection">The test's performance timer collection</param>
        public MongoTestObject(MongoDBConnectionWrapper mongoConnection, Logger logger, SoftAssert softAssert, PerfTimerCollection perfTimerCollection) : base(logger, softAssert, perfTimerCollection)
        {
            this.MongoDBWrapper = mongoConnection;
        }

        /// <summary>
        /// Gets the MongoDB connection wrapper
        /// </summary>
        public MongoDBConnectionWrapper MongoDBWrapper { get; private set; }
    }
}