using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace QlyBanDT.Controler
{
    public class TaiKhoan
    {
        string[] GRTK = { "Nhân viên", "Admin" };
        const int NhanVien = 0;
        const int Admin = 1;
        private string id, username, pw, grName;

        public string GrName
        {
            get { return grName; }
            set { grName = GRTK[ value.Equals("Admin") ? 1 : 0 ]; }
        }

        public string Pw
        {
            get { return pw; }
            set { pw = value; }
        }

        public string Username
        {
            get { return username; }
            set { username = value; }
        }

        public string Id
        {
            get { return id; }
            set { id = value; }
        }
    }
}
