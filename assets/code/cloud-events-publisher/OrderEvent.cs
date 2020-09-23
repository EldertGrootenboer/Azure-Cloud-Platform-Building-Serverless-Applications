namespace CloudEventsPublisher
{
  public class OrderEvent
  {
    public string OrderTable { get; set; }

    public string Ship { get; set; }

    public string PartitionKey { get; set; }

    public string RowKey { get; set; }
  }
}