﻿//--------------------------------------------------
// <copyright file="AppiumSoftAssert.cs" company="Magenic">
//  Copyright 2017 Magenic, All rights Reserved
// </copyright>
// <summary>This is the Appium soft assert class</summary>
//--------------------------------------------------
using Magenic.MaqsFramework.BaseTest;
using Magenic.MaqsFramework.Utilities.Data;
using Magenic.MaqsFramework.Utilities.Helper;
using Magenic.MaqsFramework.Utilities.Logging;
using OpenQA.Selenium.Appium;

namespace Magenic.MaqsFramework.BaseAppiumTest
{
    /// <summary>
    /// Soft Assert override for appium tests
    /// </summary>
    public class AppiumSoftAssert : SoftAssert
    {
        /// <summary>
        /// AppiumDriver to be used
        /// </summary>
        private AppiumDriver<AppiumWebElement> appiumDriver;

        /// <summary>
        /// Initializes a new instance of the AppiumSoftAssert class
        /// </summary>
        /// <param name="driver">The appium driver to use</param>
        /// <param name="logger">The logger to use</param>
        public AppiumSoftAssert(AppiumDriver<AppiumWebElement> driver, Logger logger)
            : base(logger)
        {
            this.appiumDriver = driver;
        }

        /// <summary>
        /// Soft assert method to check if the files are equal
        /// </summary>
        /// <param name="expectedText">Expected text</param>
        /// <param name="actualText">Actual text</param>
        /// <param name="softAssertName">Soft assert name</param>
        /// <param name="message">Exception message if desired</param>
        /// <returns>Boolean if the assert is true</returns>
        public override bool AreEqual(string expectedText, string actualText, string softAssertName, string message = "")
        {
            bool didPass = base.AreEqual(expectedText, actualText, softAssertName, message);
            if (!didPass)
            {
                if (Config.GetValue("SoftAssertScreenshot", "No").ToUpper().Equals("YES"))
                {
                    AppiumUtilities.CaptureScreenshot(this.appiumDriver, this.Log, this.TextToAppend(softAssertName));
                }

                if (Config.GetValue("SavePagesourceOnFail", "No").ToUpper().Equals("YES"))
                {
                    AppiumUtilities.SavePageSource(this.appiumDriver, this.Log, StringProcessor.SafeFormatter(" ({0})", this.NumberOfAsserts));
                }

                return false;
            }

            return true;
        }

        /// <summary>
        /// Method to determine the text to be appended to the screenshot file names
        /// </summary>
        /// <param name="softAssertName">Soft assert name</param>
        /// <returns>String to be appended</returns>
        private string TextToAppend(string softAssertName)
        {
            string appendToFileName = string.Empty;

            // If softAssertName name is not provided only append the AssertNumber
            if (softAssertName == string.Empty)
            {
                appendToFileName = StringProcessor.SafeFormatter(" ({0})", this.NumberOfAsserts);
            }
            else
            {
                // Make sure that softAssertName has valid file name characters only
                foreach (char invalidChar in System.IO.Path.GetInvalidFileNameChars())
                {
                    softAssertName = softAssertName.Replace(invalidChar, '~');
                }

                // If softAssertName is provided, use combination of softAssertName and AssertNumber 
                appendToFileName = " " + softAssertName + StringProcessor.SafeFormatter(" ({0})", this.NumberOfAsserts);
            }

            return appendToFileName;
        }
    }
}
