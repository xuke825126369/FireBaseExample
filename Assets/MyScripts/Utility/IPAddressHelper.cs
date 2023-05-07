using System.Collections.Generic;
using System.Net;
using System.Net.NetworkInformation;
using System.Net.Sockets;
using UnityEngine;
using XLua;

[LuaCallCSharp]
public class IPAddressHelper : Singleton<IPAddressHelper>
{
    public bool IsJuYuWangIp(string strIpV4)
    {
        string[] a = strIpV4.Split('.');
        if (a.Length != 4)
        {
            return false;
        }

        int[] b = new int[4];
        for (int i = 0; i < a.Length; i++)
        {
            int t = -1;
            if (int.TryParse(a[i], out t))
            {
                if (t < 0 || t > 255)
                {
                    return false;
                }

                b[i] = t;
            }
            else
            {
                return false;
            }
        }

        if (b[0] != 10 && b[0] != 172 && b[0] != 192)
        {
            return false;
        }

        if(b[0] == 172)
        {
            if(b[1] < 16 || b[1] > 31)
            {
                return false;
            }
        }
        else if(b[0] == 192)
        {
            if(b[1] != 168)
            {
                return false;
            }
        }
        
        return true;
    }

    public List<string> GetLocalNetIpList()
    {
        List<string> mIpList = new List<string>();
        NetworkInterface[] adapters = NetworkInterface.GetAllNetworkInterfaces();
        foreach (NetworkInterface adapter in adapters)
        {
            if (adapter.Supports(NetworkInterfaceComponent.IPv4))
            {
                UnicastIPAddressInformationCollection uniCast = adapter.GetIPProperties().UnicastAddresses;
                if (uniCast.Count > 0)
                {
                    foreach (UnicastIPAddressInformation uni in uniCast)
                    {
                        //得到IPv4的地址。 AddressFamily.InterNetwork指的是IPv4
                        if (uni.Address.AddressFamily == AddressFamily.InterNetwork)
                        {
                            string AddressIP = uni.Address.ToString();
                            if (IsJuYuWangIp(AddressIP))
                            {
                                //Debug.Log("局域网 AddressIP: " + AddressIP);
                                mIpList.Add(AddressIP);
                            }
                            else
                            {
                                //Debug.Log("AddressIP: " + AddressIP);
                            }
                        }
                    }
                }
            }
        }

        return mIpList;
    }

    public string GetLocalNetIp()
    {
        string ip = "?";
        List<string> mIpList = GetLocalNetIpList();
        mIpList.RemoveAll((x) => x.StartsWith("10."));//排除大型局域网Ip，因为家里的带宽都是在运营商部署的大型局域网里的
        
        if (mIpList.Count > 0)
        {
            mIpList.Sort((string x, string y) =>
            {
                string[] a = x.Split('.');
                string[] b = y.Split('.');
                int t1 = int.Parse(a[0]);
                int t2 = int.Parse(b[0]);

                return t1 - t2;
            });

            ip = mIpList[mIpList.Count - 1];
        }

        return ip;
    }

    public string GetInterNetIp(string wwwName)
    {
        IPHostEntry mIPHostEntry = Dns.GetHostEntry(wwwName);
        foreach(var v in mIPHostEntry.AddressList)
        {
            Debug.Log(v.ToString());
        }

        return mIPHostEntry.AddressList[0].ToString();
    }

}
