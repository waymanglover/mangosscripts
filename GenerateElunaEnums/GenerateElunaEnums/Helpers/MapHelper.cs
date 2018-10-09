using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using GenerateElunaEnums.Classes;

namespace GenerateElunaEnums.Helpers
{
   static class MapHelper
   {

      private static int[] mapBlacklist = {
                                             269, // CAVERNS_OF_TIME
                                             169, // EMERALD_DREAM
                                             37,  // AZSHARA_CRATER
                                          };

      public static Dictionary<Map.InstanceTypes, List<Map>> CreateMapDictionary(List<Map> maps)
      {
         var dict = new Dictionary<Map.InstanceTypes, List<Map>>();
         foreach (Map map in maps)
         {
            // Skip test/debug maps.
            if (   map.MapName_enUS.Contains("unused")
                || map.MapName_enUS.Contains("Development")
                || map.MapName_enUS.Contains("Test")
                || mapBlacklist.Contains(map.ID))
               continue;

            if (dict.ContainsKey(map.InstanceType))
            {
               dict[map.InstanceType].Add(map);
            }
            else
            {
               dict[map.InstanceType] = new List<Map>() { map };
            }
         }
         return dict;
      }
   }
}
