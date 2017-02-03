//--------------------------------------------------
// <copyright file="Program.cs" company="Magenic">
//  Copyright 2015 Magenic, All rights Reserved
// </copyright>
// <summary>Program to load performance timer files into the MAQS Performance database</summary>
//--------------------------------------------------
using Magenic.MaqsFramework.BaseDatabaseTest;
using Magenic.MaqsFramework.Utilities.Performance;
using Newtonsoft.Json;
using System;
using System.Data;
using System.IO;

namespace MaqsPerfPublish
{
    /// <summary>
    /// This is a demonstration tool which loads performance data, recorded via the PerformanceCollection capabilities in MAQS, into a MAQS Performance database
    /// </summary>
    public class Program
    {
        /// <summary>
        /// this is the database connection for the MAQS Performance database
        /// </summary>
        private static DatabaseConnectionWrapper db;

        /// <summary>
        /// Main program method
        /// </summary>
        /// <param name="args">List of Performance Log XML files to be processed</param>
        public static void Main(string[] args)
        {
            //// Get the connection string to your DB and open the connection
            string connection = DatabaseConfig.GetConnectionString();
            db = new DatabaseConnectionWrapper(connection);

            for (int i = 0; i < args.Length; i++)
            {
                Console.Write("================ Filename: {0} ===================", args[i]);
                if (File.Exists(args[i]))
                {
                    Console.WriteLine(" LOADING...");
                    try
                    {
                        LoadFile(args[i]);
                    }
                    catch (Exception e)
                    {
                        Console.WriteLine("Exception while processing file: " + e.Message);
                        Console.WriteLine("Moving on to next file!");
                    }
                }
                else
                {
                    Console.WriteLine("Does not exist!");
                }
            }

            Console.Write("Press Any Key.....");
            Console.ReadKey();
        }

        /// <summary>
        /// Load a single file into the Database
        /// </summary>
        /// <param name="fileName">The file to be loaded</param>
        public static void LoadFile(string fileName)
        {
            //// ID holder declarations
            string test_ID = null;
            string context_ID = null;
            string configuration_ID = null;
            string timerName_ID = null;
            string timer_ID = null;

            //// Create the PerfTimerCollection that we will use to index through the input file
            PerfTimerCollection pc;
            PerfTimerCollection loader = new PerfTimerCollection(string.Empty);

            //// Now we load the collection from the current file name
            pc = loader.LoadPerfTimerCollection(fileName);

            //// Get/Create the Timer_ID and Configuration_ID needed for this file
            Console.WriteLine("File Name: {0}", fileName);
            Console.WriteLine("Test Name: {0}", pc.TestName);
            test_ID = PostTest(pc.TestName);
            
            Console.WriteLine("Test Payload: [{0}]", pc.PerfPayloadString);
            configuration_ID = PostJSONConfig(pc.PerfPayloadString);
            if (configuration_ID.Length == 0)
            {
                //// We have an error condition on the configuration format, abort this file
                return;
            }

            foreach (PerfTimer t in pc.Timerlist)
            {
                Console.WriteLine("_____Timer________");
                Console.WriteLine("Name   : {0}", t.TimerName);
                Console.WriteLine("Context: {0}", t.TimerContext);
                Console.WriteLine("Start  : {0}", t.StartTime.ToString());
                Console.WriteLine("End    : {0}", t.EndTime.ToString());
                Console.WriteLine("Dur    : {0}", t.Duration.ToString());
                Console.WriteLine("Ticks  : {0}", t.DurationTicks.ToString());
                Console.WriteLine("_____________");
                //// Get/create Context_ID and TimerName_ID for this particular timer
                context_ID = PostContext(t.TimerContext);
                timerName_ID = PostTimerName(t.TimerName);

                //// Now we can insert the actual timer into the DB
                timer_ID = PostTimer(timerName_ID, context_ID, configuration_ID, test_ID, t);
                Console.WriteLine("Timer: ID = {0}", timer_ID);
            }
        }

        /// <summary>
        /// Put the timer into the database
        /// </summary>
        /// <param name="timerName_ID">ID of the name for the timer</param>
        /// <param name="context_ID">ID of the context of the timer</param>
        /// <param name="configuration_ID">ID of the configuration the test was running on when it logged the timer</param>
        /// <param name="test_ID">ID of the test that logged the timer</param>
        /// <param name="timer">The timer object</param>
        /// <returns>string - the timer ID</returns>
        /// <exception cref="System.Data.SqlClient.SqlException">Thrown by the database access layer on error </exception>        
        /// <exception cref="ApplicationException">Thrown if number of records created does not match expectations</exception>
        private static string PostTimer(string timerName_ID, string context_ID, string configuration_ID, string test_ID, PerfTimer timer)
        {
            int i;
            string id;
            string insertString = string.Format(
                "insert into dbo.Timer (Timer_ID, Context_ID, Configuration_ID, Test_ID, TimerName_ID, StartTime, EndTime, Duration) VALUES (NEWID(), \'{0}\', \'{1}\', \'{2}\', \'{3}\', \'{4}\', \'{5}\', {6})",
                context_ID, 
                configuration_ID, 
                test_ID, 
                timerName_ID, 
                timer.StartTime.ToString(), 
                timer.EndTime.ToString(), 
                timer.DurationTicks.ToString());

            string queryString = string.Format(
               "select * from  dbo.Timer where Context_ID = \'{0}\' and Configuration_ID = \'{1}\' and Test_ID = \'{2}\' and TimerName_ID = \'{3}\' and StartTime = \'{4}\' and EndTime = \'{5}\' and Duration = {6}",
               context_ID, 
               configuration_ID, 
               test_ID, 
               timerName_ID, 
               timer.StartTime.ToString(), 
               timer.EndTime.ToString(), 
               timer.DurationTicks.ToString());

            Console.WriteLine("Checking for Timer: {0}", queryString);
            //// return the current ID it one already exists.
            DataTable trow = db.QueryAndGetDataTable(queryString);
            if (trow.Rows.Count != 0)
            {
                //// This timer is already there!
                Console.WriteLine("Timer Already Posted: ID = {0}", trow.Rows[0]["Timer_ID"].ToString());
                return trow.Rows[0]["Timer_ID"].ToString();
            }

            //// Insert the timer
            Console.WriteLine("Inserting Timer");
            i = db.NonQueryAndGetRowsAffected(insertString);
            
            //// verify we cut one, and only one, record
            if (i != 1)
            {
                throw new ApplicationException("Expected to create 1 record, DB reports " + i.ToString());
            }

            trow = db.QueryAndGetDataTable(queryString);
            id = trow.Rows[0]["Timer_ID"].ToString();
            return id;
        }

        /// <summary>
        /// Creates a TimerName record, if not already there, and returns the ID
        /// </summary>
        /// <param name="timerName">The Name of the timer to create</param>
        /// <returns>A string containing the ID of the Timer Name</returns>
        private static string PostTimerName(string timerName)
        {
            return Get_ID("TimerName", timerName);
        }

        /// <summary>
        /// Creates a Context record, if not already there, and returns the ID
        /// </summary>
        /// <param name="timerContext">The Context to create</param>
        /// <returns>A string containing the ID of the Context</returns>
        private static string PostContext(string timerContext)
        {
            return Get_ID("Context", timerContext);
        }

        /// <summary>
        /// De-serialize and load the configuration from the JSON string provided
        /// </summary>
        /// <param name="configString">The JSON string containing the configuration information <typeparamref name="TConfig"/></param>
        /// <returns>A string containing the ID of the Configuration record</returns>
        /// <exception cref="JsonException">Thrown if the configString is not valid JSON syntax</exception>
        /// <exception cref="System.Data.SqlClient.SqlException">Thrown by the database access layer on error </exception>        
        /// <exception cref="ApplicationException">Thrown if number of records created does not match expectations</exception>
        private static string PostJSONConfig(string configString)
        {
            string blankConfigString = @"select * from dbo.Configuration where App_Instance = '' and DB_Instance = '' and App_Version = '' and Browser = '' and Browser_OS = ''";
            string insertString = @"insert into dbo.Configuration (Configuration_ID, App_Instance, DB_Instance, App_Version, Browser, Browser_OS) values (NEWID(),'{0}','{1}','{2}','{3}','{4}')";
            string selectString = @"select * from dbo.Configuration where App_Instance = '{0}' and DB_Instance = '{1}' and App_Version = '{2}' and Browser = '{3}' and Browser_OS = '{4}'";

            //// Always use the empty config, for now...

            DataTable trow = db.QueryAndGetDataTable(blankConfigString);

            if (configString.Length == 0)
            {
                //// return the "empty config" ID
                return trow.Rows[0]["Configuration_ID"].ToString();
            }
            else
            {
                Tconfig config;
                //// De-serialize the ConfigString
                config = JsonConvert.DeserializeObject<Tconfig>(configString);

                //// Format our SQL strings
                string getID = string.Format(selectString, config.WebURI, string.Empty, string.Empty, config.Browser, config.BrowserOS);
                string istr = string.Format(insertString, config.WebURI, string.Empty, string.Empty, config.Browser, config.BrowserOS);

                //// Check if we have this Config
                Console.WriteLine("Check for existing config.. SQL = {0}", getID);

                trow = db.QueryAndGetDataTable(getID);
                if (trow.Rows.Count > 0)
                {
                    Console.WriteLine("Config Already Posted: ID = {0}", trow.Rows[0]["Configuration_ID"].ToString());
                    //// return the ID we already have.
                    return trow.Rows[0]["Configuration_ID"].ToString();
                }

                //// Insert the row
                Console.WriteLine("None found, insert it.  SQL = {0}", istr);
                int i = db.NonQueryAndGetRowsAffected(istr);
                //// verify we cut one, and only one, record
                if (i != 1)
                {
                    throw new ApplicationException("Expected to create 1 record, DB reports " + i.ToString());
                }

                //// Get the one we just created and return it.
                trow = db.QueryAndGetDataTable(getID);
                Console.WriteLine("Config  Posted: ID = {0}", trow.Rows[0]["Configuration_ID"].ToString());
                return trow.Rows[0]["Configuration_ID"].ToString();
            }
        }

        /// <summary>
        /// Creates a Test record, if not already there, and returns the ID
        /// </summary>
        /// <param name="testName">The Context to create</param>
        /// <returns>A string containing the ID of the Test Name</returns>
        private static string PostTest(string testName)
        {
            return Get_ID("Test", testName);
        }

        /// <summary>
        /// Generic function to factor out the logic to creates a record in a table, if not already there, and returns the ID
        /// This works because the normalization tables are all Name/ID pairs that we are generating.
        /// </summary>
        /// <param name="table">The database table in which to create the record</param>
        /// <param name="name">The value for the Name field in the record that is being created</param>
        /// <returns>A string containing the ID of the Test Name</returns>
        /// <exception cref="System.Data.SqlClient.SqlException">Thrown by the database access layer on error </exception>
        /// <exception cref="DataException">Thrown if more than one record is found in a table that is intended to be unique rows</exception>
        private static string Get_ID(string table, string name) 
        { 
            int i;
            string id;

            DataTable trow = db.QueryAndGetDataTable("select * from dbo." + table + " where name = \'" + name + "\'");
            switch (trow.Rows.Count)
            {
                case 0:
                    //// we have a new one, add it
                    Console.WriteLine("Adding name: {0} in the DB table {1}", name, table);
                    i = db.NonQueryAndGetRowsAffected("insert into dbo." + table + " (" + table + "_ID, Name) VALUES (NEWID(), \'" + name + "\')");
                    Console.WriteLine("Add effected {0} rows.", i);
                    trow = db.QueryAndGetDataTable("select * from dbo." + table + " where name = \'" + name + "\'");
                    break;
               case 1:
                    //// already exists, continue
                    Console.WriteLine("Name: {0} already in the DB table {1}", name, table);
                    break;
                default:
                    //// More than one with matching name - DB inconsistency!!!
                    string msg = string.Format("WHOA! Search of Table: {0} for Name: {1} returned {2} rows!", table, name, trow.Rows.Count);
                    throw new DataException(msg);
            }

            id = trow.Rows[0][table + "_ID"].ToString();
            return id;
        }
    }
}
