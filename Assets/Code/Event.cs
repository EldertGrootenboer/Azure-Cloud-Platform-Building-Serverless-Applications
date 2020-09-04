using System;

namespace Eldert.EventGrid.SendToTopic
{
    /// <summary>
    /// Event to be sent to Event Grid Topic.
    /// </summary>
    public class Event
    {
        /// <summary>
        /// This will be used to update the Subject and Data properties.
        /// </summary>
        public ShipEvent UpdateProperties
        {
            set
            {
                Subject = $"{value.Ship}/{value.Type}";
                Data = value;
            }
        }

        /// <summary>
        /// Gets the unique identifier for the event.
        /// </summary>
        public string Id { get; }

        /// <summary>
        /// Gets the publisher defined path to the event subject.
        /// </summary>
        public string Subject { get; set; }

        /// <summary>
        /// Gets the registered event type for this event source.
        /// </summary>
        public string EventType { get; }

        /// <summary>
        /// Gets the time the event is generated based on the provider's UTC time.
        /// </summary>
        public string EventTime { get; }

        /// <summary>
        /// Gets or sets the event data specific to the resource provider.
        /// </summary>
        public ShipEvent Data { get; set; }

        /// <summary>
        /// Constructor.
        /// </summary>
        public Event()
        {
            Id = Guid.NewGuid().ToString();
            EventType = "shipevent";
            EventTime = DateTime.UtcNow.ToString("o");
        }
    }
}