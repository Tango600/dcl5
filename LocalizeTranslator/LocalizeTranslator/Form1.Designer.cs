namespace LocalizeTranslator
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Form1));
            this.gridTranslations = new System.Windows.Forms.DataGridView();
            this.Key = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.Translate = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.btSave = new System.Windows.Forms.Button();
            this.btOpen = new System.Windows.Forms.Button();
            this.openFileDialog1 = new System.Windows.Forms.OpenFileDialog();
            this.saveFileDialog1 = new System.Windows.Forms.SaveFileDialog();
            this.chSaveAs = new System.Windows.Forms.CheckBox();
            ((System.ComponentModel.ISupportInitialize)(this.gridTranslations)).BeginInit();
            this.SuspendLayout();
            // 
            // gridTranslations
            // 
            this.gridTranslations.AllowUserToAddRows = false;
            this.gridTranslations.AllowUserToDeleteRows = false;
            this.gridTranslations.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.gridTranslations.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.Key,
            this.Translate});
            this.gridTranslations.Dock = System.Windows.Forms.DockStyle.Top;
            this.gridTranslations.Location = new System.Drawing.Point(0, 0);
            this.gridTranslations.MultiSelect = false;
            this.gridTranslations.Name = "gridTranslations";
            this.gridTranslations.RightToLeft = System.Windows.Forms.RightToLeft.No;
            this.gridTranslations.Size = new System.Drawing.Size(586, 456);
            this.gridTranslations.TabIndex = 0;
            // 
            // Key
            // 
            this.Key.Frozen = true;
            this.Key.HeaderText = "Key";
            this.Key.Name = "Key";
            this.Key.ReadOnly = true;
            this.Key.Width = 150;
            // 
            // Translate
            // 
            this.Translate.FillWeight = 250F;
            this.Translate.Frozen = true;
            this.Translate.HeaderText = "Translation";
            this.Translate.MinimumWidth = 50;
            this.Translate.Name = "Translate";
            this.Translate.Width = 250;
            // 
            // btSave
            // 
            this.btSave.Location = new System.Drawing.Point(12, 474);
            this.btSave.Name = "btSave";
            this.btSave.Size = new System.Drawing.Size(75, 23);
            this.btSave.TabIndex = 1;
            this.btSave.Text = "Save";
            this.btSave.UseVisualStyleBackColor = true;
            this.btSave.Click += new System.EventHandler(this.btSave_Click);
            // 
            // btOpen
            // 
            this.btOpen.Location = new System.Drawing.Point(499, 474);
            this.btOpen.Name = "btOpen";
            this.btOpen.Size = new System.Drawing.Size(75, 23);
            this.btOpen.TabIndex = 2;
            this.btOpen.Text = "Open";
            this.btOpen.UseVisualStyleBackColor = true;
            this.btOpen.Click += new System.EventHandler(this.btOpen_Click);
            // 
            // chSaveAs
            // 
            this.chSaveAs.AutoSize = true;
            this.chSaveAs.Location = new System.Drawing.Point(104, 480);
            this.chSaveAs.Name = "chSaveAs";
            this.chSaveAs.Size = new System.Drawing.Size(74, 17);
            this.chSaveAs.TabIndex = 3;
            this.chSaveAs.Text = "Save as...";
            this.chSaveAs.UseVisualStyleBackColor = true;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(586, 509);
            this.Controls.Add(this.chSaveAs);
            this.Controls.Add(this.btOpen);
            this.Controls.Add(this.btSave);
            this.Controls.Add(this.gridTranslations);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "Form1";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "DCL Translations editor";
            ((System.ComponentModel.ISupportInitialize)(this.gridTranslations)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        private System.Windows.Forms.DataGridView gridTranslations;
        private System.Windows.Forms.Button btSave;
        private System.Windows.Forms.Button btOpen;
        private System.Windows.Forms.OpenFileDialog openFileDialog1;
        private System.Windows.Forms.DataGridViewTextBoxColumn Key;
        private System.Windows.Forms.DataGridViewTextBoxColumn Translate;
        private System.Windows.Forms.SaveFileDialog saveFileDialog1;
        private System.Windows.Forms.CheckBox chSaveAs;
    }
}

