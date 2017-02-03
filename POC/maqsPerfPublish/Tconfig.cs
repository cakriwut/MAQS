//--------------------------------------------------
// <copyright file="TConfig.cs" company="Magenic">
//  Copyright 2015 Magenic, All rights Reserved
// </copyright>
// <summary>Example Configuration definition for Json</summary>
//--------------------------------------------------
using Newtonsoft.Json;

namespace MaqsPerfPublish
{
    /// <summary>
    /// Example class to save in the payload element of the performance timer collection
    /// </summary>
    public class Tconfig
    {
        /// <summary>
        /// Gets or sets the Log Path
        /// </summary>
        [JsonProperty("Browser")]
        public string Browser { get; set; }

        /// <summary>
        /// Gets or sets the Log Path
        /// </summary>
        [JsonProperty("BrowserOS")]
        public string BrowserOS { get; set; }

        /// <summary>
        /// Gets or sets the Log type
        /// </summary>
        [JsonProperty("Env")]
        public string Env { get; set; }

        /// <summary>
        /// Gets or sets the Web URI
        /// </summary>
        [JsonProperty("WebURI")]
        public string WebURI { get; set; }
    }
}
