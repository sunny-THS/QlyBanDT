using QlyBanDT.Controler;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace QlyBanDT.DAO
{
    public class DAOTaiKhoan : ConnectSQL
    {
        TaiKhoan tk;
        string message;

        public string Message
        {
            get { return message; }
            set { message = value; }
        }
        public DAOTaiKhoan()
        { }
        public DAOTaiKhoan(string username, string pw, string grName)
        {
            tk = new TaiKhoan();
            tk.Username = username;
            tk.Pw = pw;
            tk.GrName = grName;
        }
        public bool CKDangNhap()
        {
            bool ck = false;
            try
            {
                this.Open();

                string strSql = "sp_CKAcc";
                this.sqlCmd.CommandText = strSql;
                this.sqlCmd.Connection = this.conn;
                this.sqlCmd.CommandType = CommandType.StoredProcedure;

                // truyền tham số cho proc
                this.sqlCmd.Parameters.AddWithValue("@userName", tk.Username);
                this.sqlCmd.Parameters.AddWithValue("@pw", tk.Pw);
                this.sqlCmd.Parameters.AddWithValue("@GRNAME", tk.GrName);

                SqlDataReader rd = this.sqlCmd.ExecuteReader();

                if (rd.Read())
                {
                    ck = rd["Message"].ToString().Equals("SUCCESS");
                    this.message = rd["Message"].ToString();
                }
                rd.Close();
                this.Close(); // đóng kết nối
            }
            catch (Exception)
            {
                ck = false;
            }
            
            return ck;
        }
    }
}
