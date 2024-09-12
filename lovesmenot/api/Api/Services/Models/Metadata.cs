namespace Api.Services.Models
{
    public class Metadata
    {
        /// <remarks>
        /// For future use. If we ever want to partition ratings by region, 
        /// this value will help with migration.
        /// Possible values as of now:
        ///  * aws-af-south-1
        ///  * aws-ap-east-1
        ///  * aws-ap-northeast-1
        ///  * aws-ap-northeast-2
        ///  * aws-ap-south-1
        ///  * aws-ap-southeast-1
        ///  * aws-ap-southeast-2
        ///  * aws-ca-central-1
        ///  * aws-eu-central-1
        ///  * aws-eu-north-1
        ///  * aws-eu-west-1
        ///  * aws-eu-west-2
        ///  * aws-me-south-1
        ///  * aws-sa-east-1
        ///  * aws-us-east-1
        ///  * aws-us-east-2
        ///  * aws-us-west-1
        ///  * aws-us-west-2
        /// </remarks>
        public List<string>? Regions { get; set; }
    }
}
