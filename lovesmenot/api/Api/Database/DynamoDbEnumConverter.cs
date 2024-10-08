using Amazon.DynamoDBv2.DataModel;
using Amazon.DynamoDBv2.DocumentModel;

public class DynamoDbEnumConverter<T> : IPropertyConverter where T : struct
{
    public DynamoDBEntry ToEntry(object value)
    {
        return new Primitive
        {
            Value = Enum.Format(typeof(T), value, "G")
        };
    }

    public object FromEntry(DynamoDBEntry entry)
    {
        var enumValue = (entry as Primitive)?.Value as string;
        if (enumValue == null)
            throw new ArgumentException("Invalid entry to convert to enum");

        return Enum.Parse<T>(enumValue);
    }
}