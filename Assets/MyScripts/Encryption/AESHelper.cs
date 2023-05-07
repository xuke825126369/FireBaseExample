using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using UnityEngine;

public static class AESHelper
{
    static byte[] ASample = Encoding.ASCII.GetBytes("2022-08-21-fixbug");
    static byte[] BSample = Encoding.ASCII.GetBytes(Application.identifier.ToUpper() + Application.identifier.ToLower());

    static readonly byte[] mKeyValue = null;
    static readonly byte[] mIVValue = null;

    static AESHelper()
    {
        using (Aes myAes = Aes.Create())
        {
            int nIVSize = myAes.BlockSize / 8;
            int nKeySize = nIVSize;//和IV长度一样吧，其他都会报错

            byte[] KeyValue = new byte[nKeySize];
            for (int i = 0; i < KeyValue.Length; i++)
            {
                KeyValue[i] = ASample[i % ASample.Length];
            }

            byte[] IVValue = new byte[nIVSize];
            for (int i = 0; i < IVValue.Length; i++)
            {
                IVValue[i] = BSample[i % BSample.Length];
            }

            myAes.Key = KeyValue;
            myAes.IV = IVValue;

            mKeyValue = KeyValue;
            mIVValue = IVValue;
        }
    }

    public static string Encode(string original)
    {
        byte[] encrypted = EncryptStringToBytes_Aes(original, mKeyValue, mIVValue);
        string roundtrip = Convert.ToBase64String(encrypted);
        return roundtrip;
    }

    public static string Decode(string original)
    {
        byte[] encrypted = Convert.FromBase64String(original);
        string roundtrip = DecryptStringFromBytes_Aes(encrypted, mKeyValue, mIVValue);
        return roundtrip;
    }

    static byte[] EncryptStringToBytes_Aes(string plainText, byte[] Key, byte[] IV)
    {
        // Check arguments.
        if (plainText == null || plainText.Length <= 0)
            throw new ArgumentNullException("plainText");
        if (Key == null || Key.Length <= 0)
            throw new ArgumentNullException("Key");
        if (IV == null || IV.Length <= 0)
            throw new ArgumentNullException("IV");
        byte[] encrypted;

        // Create an Aes object
        // with the specified key and IV.
        using (Aes aesAlg = Aes.Create())
        {
            aesAlg.Key = Key;
            aesAlg.IV = IV;

            // Create an encryptor to perform the stream transform.
            ICryptoTransform encryptor = aesAlg.CreateEncryptor(aesAlg.Key, aesAlg.IV);

            // Create the streams used for encryption.
            using (MemoryStream msEncrypt = new MemoryStream())
            {
                using (CryptoStream csEncrypt = new CryptoStream(msEncrypt, encryptor, CryptoStreamMode.Write))
                {
                    using (StreamWriter swEncrypt = new StreamWriter(csEncrypt))
                    {
                        //Write all data to the stream.
                        swEncrypt.Write(plainText);
                    }
                    encrypted = msEncrypt.ToArray();
                }
            }
        }

        // Return the encrypted bytes from the memory stream.
        return encrypted;
    }

    static string DecryptStringFromBytes_Aes(byte[] cipherText, byte[] Key, byte[] IV)
    {
        // Check arguments.
        if (cipherText == null || cipherText.Length <= 0)
            throw new ArgumentNullException("cipherText");
        if (Key == null || Key.Length <= 0)
            throw new ArgumentNullException("Key");
        if (IV == null || IV.Length <= 0)
            throw new ArgumentNullException("IV");

        // Declare the string used to hold
        // the decrypted text.
        string plaintext = null;

        // Create an Aes object
        // with the specified key and IV.
        using (Aes aesAlg = Aes.Create())
        {
            aesAlg.Key = Key;
            aesAlg.IV = IV;

            // Create a decryptor to perform the stream transform.
            ICryptoTransform decryptor = aesAlg.CreateDecryptor(aesAlg.Key, aesAlg.IV);

            // Create the streams used for decryption.
            using (MemoryStream msDecrypt = new MemoryStream(cipherText))
            {
                using (CryptoStream csDecrypt = new CryptoStream(msDecrypt, decryptor, CryptoStreamMode.Read))
                {
                    using (StreamReader srDecrypt = new StreamReader(csDecrypt))
                    {

                        // Read the decrypted bytes from the decrypting stream
                        // and place them in a string.
                        plaintext = srDecrypt.ReadToEnd();
                    }
                }
            }
        }

        return plaintext;
    }
}