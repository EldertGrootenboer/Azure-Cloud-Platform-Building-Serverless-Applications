using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Table;
using Newtonsoft.Json;
using System;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace CloudEventsPublisher
{
  internal class Program
  {
    private const string TOPIC_ENDPOINT = "https://cloudtrinityorders.westeurope-1.eventgrid.azure.net/api/events";
    private const string KEY = "";
    private const string STORAGE_ENDPOINT = "DefaultEndpointsProtocol=https;AccountName=cloudtrinity;AccountKey=;EndpointSuffix=core.windows.net";

    public static void Main(string[] args)
    {
      while (true)
      {
        Console.WriteLine("What is the name of the ship?");
        string str1 = Console.ReadLine();
        Console.WriteLine("What would you like to order?");
        string str2 = Console.ReadLine();
        Console.WriteLine("How many would you like to order?");
        int int32 = Convert.ToInt32(Console.ReadLine());
        Order order1 = new Order();
        order1.PartitionKey = str1;
        order1.RowKey = DateTime.UtcNow.ToString("dd-MM-yyyy HH:mm:ss");
        order1.Ship = str1;
        order1.Date = DateTime.UtcNow;
        order1.Product = str2;
        order1.Amount = int32;
        order1.Email = "order_" + str1.Replace(" ", string.Empty).ToLower() + "@eldert.org";
        Order order2 = order1;
        CloudTable tableReference = CloudStorageAccount.Parse(STORAGE_ENDPOINT).CreateCloudTableClient().GetTableReference("Orders");
        TableOperation operation = TableOperation.Insert((ITableEntity) order2);
        tableReference.ExecuteAsync(operation, (TableRequestOptions) null, (OperationContext) null).Wait();
        OrderEvent orderEvent = new OrderEvent()
        {
          Ship = order2.Ship,
          PartitionKey = order2.PartitionKey,
          RowKey = order2.RowKey,
          OrderTable = tableReference.Uri.AbsoluteUri
        };
        Program.SendEventsToTopic(new CloudEvents()
        {
          UpdateProperties = orderEvent
        }).Wait();
      }
    }

    private static async Task SendEventsToTopic(CloudEvents cloudEvents)
    {
      HttpClient httpClient = new HttpClient();
      httpClient.DefaultRequestHeaders.Add("aeg-sas-key", KEY);
      string json = JsonConvert.SerializeObject((object) new[] { cloudEvents });
      StringContent content = new StringContent(json, Encoding.UTF8, "application/cloudevents+json");
      Console.WriteLine("Sending event to Event Grid...");
      HttpResponseMessage result1 = await httpClient.PostAsync("https://enfi3vhaiwaiq.x.pipedream.net/", (HttpContent) content);
      HttpResponseMessage result = await httpClient.PostAsync(TOPIC_ENDPOINT, (HttpContent) content);
      Console.WriteLine("Event sent with result: " + result.ReasonPhrase);
      Console.WriteLine();
    }
  }
}
