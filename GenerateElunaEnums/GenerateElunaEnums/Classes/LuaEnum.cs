using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GenerateElunaEnums.Classes
{
   class LuaEnum
   {
      public string name;
      public List<LuaEnumValue> values;

      public LuaEnum()
      {
         name = null;
         values = new List<LuaEnumValue>();
      }

      public override string ToString()
      {
         StringBuilder sb = new StringBuilder();
         sb.Append($"{name} = readOnlyTable {{{System.Environment.NewLine}");
         foreach (LuaEnumValue value in values)
         {
            sb.Append($"  {value}{System.Environment.NewLine}");
         }
         sb.Append(@"}");
         return sb.ToString();
      }
   }
}
