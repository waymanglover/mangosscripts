using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace GenerateElunaEnums.Classes
{
   public class Map
   {
      public int ID { get; set; }
      public string OrgrimmarInstance { get; set; }
      public InstanceTypes InstanceType { get; set; }
      public string PVP { get; set; }
      public string MapName_enUS { get; set; }
      public string MapName_enGB { get; set; }
      public string MapName_koKR { get; set; }
      public string MapName_frFR { get; set; }
      public string MapName_deDE { get; set; }
      public string MapName_enCN { get; set; }
      public string MapName_zhCN { get; set; }
      public string MapName_enTW { get; set; }
      public string MapName_Mask { get; set; }
      public int MinLevel { get; set; }
      public int MaxLevel { get; set; }
      public int MaxPlayers { get; set; }
      public string Field08 { get; set; }
      public string Field09 { get; set; }
      public string Field10 { get; set; }
      public string AreaTableID { get; set; }
      public string MapDescription0_enUS { get; set; }
      public string MapDescription0_enGB { get; set; }
      public string MapDescription0_koKR { get; set; }
      public string MapDescription0_frFR { get; set; }
      public string MapDescription0_deDE { get; set; }
      public string MapDescription0_enCN { get; set; }
      public string MapDescription0_zhCN { get; set; }
      public string MapDescription0_enTW { get; set; }
      public string MapDescription0_Mask { get; set; }
      public string MapDescription1_enUS { get; set; }
      public string MapDescription1_enGB { get; set; }
      public string MapDescription1_koKR { get; set; }
      public string MapDescription1_frFR { get; set; }
      public string MapDescription1_deDE { get; set; }
      public string MapDescription1_enCN { get; set; }
      public string MapDescription1_zhCN { get; set; }
      public string MapDescription1_enTW { get; set; }
      public string MapDescription1_Mask { get; set; }
      public int LoadingScreenID { get; set; }
      public string RaidOffset { get; set; }
      public string Field16 { get; set; }
      public string Field17 { get; set; }

      public enum InstanceTypes
      {
         World = 0,
         Dungeon = 1,
         Raid = 2,
         PvP = 3,
      };

      public override string ToString()
      {
         Regex regex = new Regex("[^a-zA-Z0-9 -]");
         string mapName = regex.Replace(MapName_enUS.ToUpperInvariant(), "").Replace(' ', '_');
         return $"{mapName} = {ID},";
      }
   }
}
