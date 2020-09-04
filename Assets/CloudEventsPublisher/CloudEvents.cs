using System;

namespace CloudEventsPublisher
{
  internal class CloudEvents
  {
    public OrderEvent UpdateProperties
    {
      set
      {
        this.subject = "/orders/ships/" + value.Ship;
        this.topic = "/subscriptions/fdf3a3a3-c8f5-472f-8367-6a9a4a6c11a9/resourceGroups/CloudTrinity/providers/Microsoft.EventGrid/topics/cloudtrinityorders";
        this.data = value;
      }
    }

    public string topic { get; set; }

    public string subject { get; set; }

    public string id { get; }

    public string eventType { get; }

    public string eventTime { get; }

    public OrderEvent data { get; set; }

    public string dataVersion { get; }

    public string metadataVersion { get; }

    public CloudEvents()
    {
      this.dataVersion = "1";
      this.metadataVersion = "1";
      this.id = Guid.NewGuid().ToString();
      this.eventType = "shipevent";
      this.eventTime = DateTime.UtcNow.ToString("o");
    }
  }
}
