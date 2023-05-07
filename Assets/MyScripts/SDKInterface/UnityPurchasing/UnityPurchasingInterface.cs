using System;
using System.Collections.Generic;
using System.Security.Cryptography;
using System.Text;
using UnityEngine;
using UnityEngine.Purchasing;
using XLua;

public struct CustomStoreItem
{
    public string skuId;
    public ProductType nType;

    public CustomStoreItem(string skuId, ProductType nType)
    {
        this.skuId = skuId;
        this.nType = nType;
    }
}

[LuaCallCSharp]
public class UnityPurchasingInterface : SingleTonMonoBehaviour<UnityPurchasingInterface>, IStoreListener
{
    private LuaTable mLuaTable;
    private Action<LuaTable, IStoreController, IExtensionProvider> mLuaOnInitInitialized;
    private Action<LuaTable, InitializationFailureReason> mLuaOnInitializeFailed;
    private Action<LuaTable, Product, PurchaseFailureReason> mLuaOnPurchaseFailed;
    private Action<LuaTable, PurchaseEventArgs> mLuaOnPurchaseResult;

    IGooglePlayStoreExtensions m_GooglePlayStoreExtensions = null;
    IStoreController mController = null;

    public void Init(List<CustomStoreItem> mProductItemList)
    {
        mLuaTable = LuaMainEnv.Instance.GetLuaClientEnv().Global.GetInPath<LuaTable>("UnityPurchasingHandler");
        mLuaOnInitInitialized = mLuaTable.GetInPath<Action<LuaTable, IStoreController, IExtensionProvider>>("OnInitialized");
        mLuaOnInitializeFailed = mLuaTable.GetInPath<Action<LuaTable, InitializationFailureReason>>("OnInitializeFailed");
        mLuaOnPurchaseFailed = mLuaTable.GetInPath<Action<LuaTable, Product, PurchaseFailureReason>>("OnPurchaseFailed");
        mLuaOnPurchaseResult = mLuaTable.GetInPath<Action<LuaTable, PurchaseEventArgs>>("ProcessPurchase");

        var builder = ConfigurationBuilder.Instance(StandardPurchasingModule.Instance());
        var googlePlayConfiguration = builder.Configure<IGooglePlayConfiguration>();
        ConfigureGoogleFraudDetection(googlePlayConfiguration);

        foreach (var v in mProductItemList)
        {
            builder.AddProduct(v.skuId, v.nType);
        }

        UnityPurchasing.Initialize(this, builder);
    }

    public void OnInitialized(IStoreController controller, IExtensionProvider extensions)
    {
        mController = controller;
        m_GooglePlayStoreExtensions = extensions.GetExtension<IGooglePlayStoreExtensions>();
        mLuaOnInitInitialized(mLuaTable, controller, extensions);
    }

    public void OnInitializeFailed(InitializationFailureReason error)
    {
        mLuaOnInitializeFailed(mLuaTable, error);
    }

    public void OnInitializeFailed(InitializationFailureReason error, string message)
    {
        mLuaOnInitializeFailed(mLuaTable, error);
    }

    public void OnPurchaseFailed(Product item, PurchaseFailureReason reason)
    {
        mLuaOnPurchaseFailed(mLuaTable, item, reason);
    }

    public PurchaseProcessingResult ProcessPurchase(PurchaseEventArgs e)
    {
        var product = e.purchasedProduct;
        if (m_GooglePlayStoreExtensions != null && m_GooglePlayStoreExtensions.IsPurchasedProductDeferred(product))
        {
            return PurchaseProcessingResult.Pending;
        }

        if (e.purchasedProduct.receipt != null)
        {
            Debug.Log("ProcessPurchase: " + e.purchasedProduct.receipt);
        }

        mLuaOnPurchaseResult(mLuaTable, e);
        return PurchaseProcessingResult.Complete;
    }

    //-------------------------------------------------------------------------------------------
    void ConfigureGoogleFraudDetection(IGooglePlayConfiguration googlePlayConfiguration)
    {
        //To make sure the account id and profile id do not contain personally identifiable information, we obfuscate this information by hashing it.
        string AccountId = RandomUtility.Random(1, int.MaxValue - 1).ToString();
        string ProfileId = RandomUtility.Random(1, int.MaxValue - 1).ToString();
        var obfuscatedAccountId = HashString(AccountId);
        var obfuscatedProfileId = HashString(ProfileId);
        googlePlayConfiguration.SetObfuscatedAccountId(obfuscatedAccountId);
        googlePlayConfiguration.SetObfuscatedProfileId(obfuscatedProfileId);
    }

    static string HashString(string input)
    {
        var stringBuilder = new StringBuilder();
        foreach (var b in GetHash(input))
            stringBuilder.Append(b.ToString("X2"));

        return stringBuilder.ToString();
    }

    static IEnumerable<byte> GetHash(string input)
    {
        using (HashAlgorithm algorithm = SHA256.Create())
            return algorithm.ComputeHash(Encoding.UTF8.GetBytes(input));
    }


}