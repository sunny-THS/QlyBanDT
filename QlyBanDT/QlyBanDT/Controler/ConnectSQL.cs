using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;
using System.Data.SqlClient;

namespace QlyBanDT.Controler
{
    public class ConnectSQL
    {
        private String strConnect = ConfigurationManager.ConnectionStrings["CSDL"].ConnectionString;
        protected SqlConnection conn;
        protected SqlCommand sqlCmd;

        public ConnectSQL()
        {
            conn = new SqlConnection(strConnect);
            sqlCmd = new SqlCommand();
        }
        public void Open()
        {
            if (conn.State == ConnectionState.Closed)
                conn.Open();
        }
        public void Close()
        {
            if (conn.State == ConnectionState.Open)
                conn.Close();
        }

    }
}
