﻿using Magenic.Maqs.BaseDatabaseTest;
using NUnit.Framework;
using System.Data;
using System.Linq;

namespace $safeprojectname$
{
    /// <summary>
    /// $safeprojectname$ test class
    /// </summary>
    [TestFixture]
    public class $safeitemname$ : BaseDatabaseTest
    {
        /// <summary>
        /// Get record using stored procedure
        /// </summary>
        //[Test]  Disabled because this step will fail as the template does not include access to a test database
        public void GetRecordTest()
        {
            using (DatabaseDriver wrapper = new DatabaseDriver(DatabaseConfig.GetProviderTypeString(), DatabaseConfig.GetConnectionString()))
            {
                var result = wrapper.Query("getStateAbbrevMatch", new { StateAbbreviation = "MN" }, commandType: CommandType.StoredProcedure);
                Assert.AreEqual(1, result.Count(), "Expected 1 state abbreviation to be returned.");
            }
        }
    }
}