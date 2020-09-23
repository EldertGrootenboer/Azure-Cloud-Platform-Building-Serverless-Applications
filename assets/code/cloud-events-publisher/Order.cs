using Microsoft.WindowsAzure.Storage.Table;
using System;

namespace CloudEventsPublisher
{
  public class Order : TableEntity
  {
    public string Ship { get; set; }

    public DateTime Date { get; set; }

    public string Product { get; set; }

    public int Amount { get; set; }

    public string Email { get; set; }
  }
}