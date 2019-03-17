namespace Company.Template.Data
{ 
    using System;

    public class UpdateConcurrencyException : Exception
    {
        public UpdateConcurrencyException()
        {
        }

        public UpdateConcurrencyException(string message) : base(message)
        {
        }

        public UpdateConcurrencyException(string message, Exception inner) : base(message, inner)
        {
        }
    }
}
