using System;

[XLua.LuaCallCSharp]
public class WebRequestCertificateHandler : UnityEngine.Networking.CertificateHandler
{
    protected override bool ValidateCertificate(byte[] certificateData)
    {
        return true;
    }
}
