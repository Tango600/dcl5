using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace LocalizeTranslator
{
    public partial class Form1 : Form
    {
        private string fileName = "";
        private Translations translations = new Translations();

        public Form1()
        {
            InitializeComponent();
        }

        private void btOpen_Click(object sender, EventArgs e)
        {
            if (openFileDialog1.ShowDialog() == DialogResult.OK)
            {
                fileName = openFileDialog1.FileName;
                translations = TranslationsFileParser.Parse(openFileDialog1.FileName);

                foreach (var ti in translations.Items)
                {
                    gridTranslations.Rows.Add(ti.Key, ti.Translation);
                }
            }
        }

        private void btSave_Click(object sender, EventArgs e)
        {
            if (saveFileDialog1.ShowDialog() == DialogResult.OK)
            {
                fileName = saveFileDialog1.FileName;
            }

            if (translations.Items.Any() && !string.IsNullOrEmpty(fileName))
            {
                TranslationsFileParser.Save(fileName, translations);
            }
        }
    }
}
