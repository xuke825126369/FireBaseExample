// WARNING: Do not modify! Generated file.

namespace UnityEngine.Purchasing.Security {
    public class GooglePlayTangle
    {
        private static byte[] data = System.Convert.FromBase64String("ZDbVzM2WeAJxdYus2WvQQVA5BDl4TOVkkHZ0ghcah6uvJ5/Zj2XJ5OSfl1o29j5I4e0oFfE3+IXdg31uI6rPQVSgO9kii5VA5+sYssl24/+aGRcYKJoZEhqaGRkYjmNx4X2bCzhymEY/k4kWmeg9weSO6d7rc1fBlejXHzXkZjEmIAnXqdx32bmxjpKxTsbg6Qc0esAtUiTBVx0J2Y2r/CiaGTooFR4RMp5Qnu8VGRkZHRgbo1f1L25OAEIN2amnG0GE+GycfOiuef9/HHBq3SvR6lRqakTjoAeF8p3HjZ213oNX4YH4cYKNmyTY3c9IwbZVb8iRqqfbeZbPYXKqHDmmwpEYuRq1EHpP83GuMWS04JlsjSmIxk/ISBgWMALXVRobGRgZ");
        private static int[] order = new int[] { 11,10,3,6,10,7,12,10,11,11,10,12,12,13,14 };
        private static int key = 24;

        public static readonly bool IsPopulated = true;

        public static byte[] Data() {
        	if (IsPopulated == false)
        		return null;
            return Obfuscator.DeObfuscate(data, order, key);
        }
    }
}
