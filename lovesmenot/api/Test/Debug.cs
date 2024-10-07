using AngleSharp.Dom;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using static System.Formats.Asn1.AsnWriter;

namespace Test
{
    record CodeForAccessTokenRequest(
            string code,
            string client_id,
            string grant_type,
            string redirect_uri,
            string scope,
            string client_secret
        );

    public class Debug
    {
        [Fact]
        public void Test()
        {
            var request = new CodeForAccessTokenRequest(
               "code",
               "Constants.Auth.XboxClientId",
               "authorization_code",
               "RedirectUrl",
               "Scope",
               "Constants.Auth.XboxSecret"
           );

            var serializedModel = JsonSerializer.Serialize(request);
            var x = JsonSerializer.Deserialize<Dictionary<string, string>>(serializedModel);
        }
    }
}
