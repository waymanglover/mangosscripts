using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using GenerateElunaEnums.Classes;

namespace GenerateElunaEnums.Helpers
{
   static class ElunaHooksHelper
   {
      public static string GetHooksHeader()
      {
         string html = string.Empty;
         const string url = @"https://github.com/ElunaLuaEngine/Eluna/raw/master/Hooks.h";

         ServicePointManager.Expect100Continue = true;
         ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;

         HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
         request.AutomaticDecompression = DecompressionMethods.GZip;

         using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
         using (Stream stream = response.GetResponseStream())
         using (StreamReader reader = new StreamReader(stream))
         {
            html = reader.ReadToEnd();
         }
         return html;
      }

      public static List<LuaEnum> ParseHooksHeader(string hooksHeader)
      {
         string luaString = String.Empty;
         Regex enumNameRegex = new Regex(@"enum (\w+)", RegexOptions.Compiled | RegexOptions.IgnoreCase);
         Regex enumValueRegex = new Regex(@"(\w+)\s*={0,1}\s*(\d*),{0,1}\s*\/{0,2}\s*(.*)$", RegexOptions.Compiled | RegexOptions.IgnoreCase);

         List<LuaEnum> enums = new List<LuaEnum>();
         LuaEnum currentEnum = new LuaEnum();
         using (StringReader reader = new StringReader(hooksHeader))
         {
            string line;
            int previousId = -1;
            while ((line = reader.ReadLine()) != null)
            {
               // If we don't currently have an enum to parse, try to find one
               if (currentEnum.name == null)
               {
                  Match match = enumNameRegex.Match(line);
                  if (match.Success) currentEnum.name = match.Groups[1].Value;
               }
               // If we do have an enum to parse, go into parsing mode.
               else
               {
                  // Don't need the first line or commented out lines
                  if (line.Contains(@"{") || line.Trim().StartsWith(@"//")) continue;
                  else if (line.Contains(@"}"))
                  {
                     // We've found the end of the enum.
                     enums.Add(currentEnum);
                     currentEnum = new LuaEnum();
                     previousId = -1;
                     continue;
                  }

                  // Try to get the enum values.
                  Match match = enumValueRegex.Match(line);
                  if (match.Success)
                  {
                     int id;
                     bool idIsEmpty = String.IsNullOrWhiteSpace(match.Groups[2].Value);
                     if (idIsEmpty && previousId == -1) id = 0;
                     else if (idIsEmpty) id = previousId + 1;
                     else id = Int32.Parse(match.Groups[2].Value);

                     string name = match.Groups[1].Value;
                     string comment = match.Groups[3].Value;
                     LuaEnumValue newHook = new LuaEnumValue(name, id, comment);
                     currentEnum.values.Add(newHook);

                     // Save off the previous ID in case the next value in the enum
                     // doens't have an ID specified.
                     previousId = id;
                  }
               }
            }
         }
         return enums;
      }
   }
}
