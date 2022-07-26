using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Threading.Tasks;

namespace LocalizeTranslator
{
    public class TranslationItem
    {
        public string Key;
        public string Translation;
    }

    public class Translations
    {
        public string Lang;
        public List<TranslationItem> Items = new List<TranslationItem>();
    }

    public static class TranslationsFileParser
    {
        public static Translations Parse(string FileName)
        {
            var result = new Translations();
            if (File.Exists(FileName))
            {
                var fileContent = File.ReadAllLines(FileName, Encoding.UTF8);
                var list = new List<TranslationItem>();
                result = new Translations { Items = list, Lang = Path.GetExtension(FileName).Replace(".", "").ToUpper() };
                foreach (var s in fileContent)
                {
                    int p = s.IndexOf(":=");
                    if (p > 0 && s.Replace(" ", "").IndexOf(":='") > 0 && s.LastIndexOf(";") + 1 == s.Length)
                    {
                        string key = s.Substring(0, p).Trim();
                        string translate = s.Substring(p + 2, s.Length - p - 2);
                        int p1 = translate.IndexOf("'");
                        int p2 = translate.IndexOf("'", p1 + 1);

                        list.Add(new TranslationItem { Key = key, Translation = translate.Substring(p1 + 1, p2 - p1 - 1) });
                    }
                }
            }
            return result;
        }

        public static void Save(string FileName, Translations Translations)
        {
            if (Translations.Items.Any())
            {
                var fileContent = new List<string>();

                foreach (var tr in Translations.Items)
                {
                    fileContent.Add(tr.Key + ":='" + tr.Translation + "';");
                }

                File.WriteAllText(FileName, string.Join(Environment.NewLine, fileContent));
            }
        }
    }
}
