﻿//-----------------------------------------------------
// <copyright file="SeleniumCustomConfigUnitTest.cs" company="Magenic">
//  Copyright 2018 Magenic, All rights Reserved
// </copyright>
// <summary>Test the selenium framework with a custom configuration</summary>
//-----------------------------------------------------
using Magenic.Maqs.BaseSeleniumTest;
using Magenic.Maqs.BaseSeleniumTest.Extensions;
using Magenic.Maqs.Utilities.Helper;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using OpenQA.Selenium;
using OpenQA.Selenium.PhantomJS;
using System.Diagnostics.CodeAnalysis;
using System.IO;
using System.Reflection;

namespace SeleniumUnitTests
{
    /// <summary>
    /// Test the selenium framework
    /// </summary>
    [TestClass]
    [ExcludeFromCodeCoverage]
    public class SeleniumCustomConfigUnitTest : BaseSeleniumTest
    {
        /// <summary>
        /// Google URL
        /// </summary>
        private string googleUrl = "https://www.google.com";

        /// <summary>
        /// Google search box css selector for standard visual browser
        /// <para>This selector should not be included in the Phantom JS configuration this code uses</para>
        /// </summary>
        private string searchBoxCssSelector = "#lst-ib";

        /// <summary>
        /// Verify WaitForAbsentElement wait works
        /// </summary>
        [TestMethod]
        [TestCategory(TestCategories.Selenium)]
        public void VerifyCustomBrowserUsed()
        {
            this.WebDriver.Navigate().GoToUrl(this.googleUrl);

            // With our default driver this selector will be found
            this.WebDriver.Wait().ForAbsentElement(By.CssSelector(this.searchBoxCssSelector));
        }

        /// <summary>
        /// Override the web driver we user for these tests
        /// </summary>
        /// <returns>The web driver we want to use - Web driver override</returns>
        protected override IWebDriver GetBrowser()
        {
            IWebDriver webDriver;

            string currentPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
            string binaryPath = Path.GetFullPath(Path.Combine(currentPath, "..\\..\\..\\Binaries"));

            if (File.Exists(Path.Combine(currentPath, "phantomjs.exe")))
            {
#pragma warning disable CS0618 // Type or member is obsolete
                webDriver = new PhantomJSDriver(currentPath);
#pragma warning restore CS0618 // Type or member is obsolete
            }
            else
            {
#pragma warning disable CS0618 // Type or member is obsolete
                webDriver = new PhantomJSDriver(binaryPath);
#pragma warning restore CS0618 // Type or member is obsolete
            }

            return webDriver;
        }
    }
}