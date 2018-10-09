using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GenerateElunaEnums.Classes
{
   class LuaEnumValue
   {
      public string name;
      public int id;
      public string comment;

      public LuaEnumValue(string Name, int Id, string Comment)
      {
         name = Name;
         id = Id;
         comment = Comment;
      }

      public override string ToString()
      {
         StringBuilder sb = new StringBuilder();
         sb.Append($"{name} = {id},");
         if (!String.IsNullOrWhiteSpace(comment)) sb.Append($" -- {comment}");
         return sb.ToString();
      }
   }
}
