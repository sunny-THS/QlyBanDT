using QlyBanDT.DAO;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace QlyBanDT.auth
{
    public partial class DangNhap : Form
    {
        public DangNhap()
        {
            InitializeComponent();
        }

        private void DangNhap_Load(object sender, EventArgs e)
        {

        }

        private void pictureBox2_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void btnLogin_Click(object sender, EventArgs e)
        {
            // kiểm tra rỗng
            if (this.txtUsername.Texts.Trim().Length == 0 && this.txtPw.Texts.Trim().Length == 0)
            {// cả 2 khung đều rỗng
                MessageBox.Show(
                    "Vui lòng điền thông tin đăng nhập",
                    "Thông báo",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Warning,
                    MessageBoxDefaultButton.Button1);

                this.txtUsername.Focus();
                this.txtUsername.BorderColor = Color.Red;
                this.txtPw.BorderColor = Color.Red;
                return;
            }
            else if (this.txtUsername.Texts.Trim().Length == 0)
            {// cả 2 khung đều rỗng
                MessageBox.Show(
                    "Vui lòng điền username",
                    "Thông báo",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Warning,
                    MessageBoxDefaultButton.Button1);

                this.txtUsername.Focus();
                this.txtUsername.BorderColor = Color.Red;
                return;
            }
            else if (this.txtPw.Texts.Trim().Length == 0)
            {// cả 2 khung đều rỗng
                MessageBox.Show(
                    "Vui lòng điền password",
                    "Thông báo",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Warning,
                    MessageBoxDefaultButton.Button1);

                this.txtPw.Focus();
                this.txtPw.BorderColor = Color.Red;
                return;
            }

            // xử lý input
            string[] splitStringTxtUsername = this.txtUsername.Texts.Trim().Split('\\');
            string gr = splitStringTxtUsername[0];
            string username = splitStringTxtUsername[1];

            DAOTaiKhoan qlyDangNhap = new DAOTaiKhoan(username, this.txtPw.Texts.Trim(), gr);

            if (qlyDangNhap.CKDangNhap())
                MessageBox.Show("Thành Công");
            else
                MessageBox.Show(qlyDangNhap.Message);
        }

        private void Common_Leave(object sender, EventArgs e)
        {
            if (this.txtUsername.BorderColor == Color.Red && this.txtUsername.Texts.Trim().Length != 0)
                this.txtUsername.BorderColor = Color.Black;

            if (this.txtPw.BorderColor == Color.Red && this.txtPw.Texts.Trim().Length != 0)
                this.txtPw.BorderColor = Color.Black;
        }

    }
}
