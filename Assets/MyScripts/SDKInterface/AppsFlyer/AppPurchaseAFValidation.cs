using System;
using AppsFlyerSDK;
using UnityEngine.Purchasing;
using UnityEngine.Purchasing.Security;
using UnityEngine.SocialPlatforms;
using UnityEngine;
using static UnityEngine.Networking.UnityWebRequest;
using System.Text;
using Newtonsoft.Json;
using System.Collections;

[XLua.LuaCallCSharp]
public class AppPurchaseAFValidation : SingleTonMonoBehaviour<AppPurchaseAFValidation>, IAppsFlyerValidateReceipt
{
    public void Init()
    {
        if (GameConfig.PLATFORM_EDITOR)
        {
            return;
        }

        (AppsFlyer.instance as AppsFlyerAndroid).initInAppPurchaseValidatorListener(this);
    }

    public void didFinishValidateReceipt(string result)
    {
        Debug.Log("AF didFinishValidateReceipt: " + result);
    }

    public void didFinishValidateReceiptWithError(string error)
    {
        Debug.LogError("AF didFinishValidateReceiptWithError: " + error);
    }

    public void BeginPurchaseServerValid(Product mPurchasedProduct, string nSKuDollar)
    {
        if (GameConfig.PLATFORM_EDITOR)
        {
            return;
        }

        if (!mPurchasedProduct.hasReceipt)
        {
            return;
        }

        string tranactionId = mPurchasedProduct.transactionID;
        string mSkuProductId = mPurchasedProduct.definition.id;
        Debug.Log("mSkuProductId: " + mSkuProductId);

        string payLoad_Json = string.Empty;
        string payLoad_signature = string.Empty;

        try
        {
            Hashtable mReceipt = JsonConvert.DeserializeObject<Hashtable>(mPurchasedProduct.receipt);
            if (mReceipt.ContainsKey("Payload"))
            {
                Hashtable mPayload = JsonConvert.DeserializeObject<Hashtable>(mReceipt["Payload"].ToString());
                if (mPayload.ContainsKey("json"))
                {
                    payLoad_Json = mPayload["json"].ToString();
                }

                if (mPayload.ContainsKey("signature"))
                {
                    payLoad_signature = mPayload["signature"].ToString();
                }
            }
        }
        catch (Exception e)
        {
            Debug.LogError(e.Message);
        }

        var currentAppStore = StandardPurchasingModule.Instance().appStore;
        if (currentAppStore == AppStore.GooglePlay)
        {
            string googlePublicKey = Convert.ToBase64String(GooglePlayTangle.Data());
            (AppsFlyer.instance as AppsFlyerAndroid).validateAndSendInAppPurchase(googlePublicKey, payLoad_signature, payLoad_Json, nSKuDollar, "USD", null, this);
        }
    }
}

