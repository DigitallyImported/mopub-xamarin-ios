namespace MoPubSDK
{
	public enum MPNativeAdOrientation : uint
	{
		Any,
		Portrait,
		Landscape
	}

    public enum MPConsentStatus : uint
    {
        Unknown = 0,
        Denied,
        DoNotTrack,
        PotentialWhitelist,
        Consented
    }
}
