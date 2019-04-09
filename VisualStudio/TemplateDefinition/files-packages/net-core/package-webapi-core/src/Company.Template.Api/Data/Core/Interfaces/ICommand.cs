namespace Company.Template.Data
{
    public interface ICommand<TInput>
    {
        TInput Parameter { get;  }
        bool Ok { get; }
        void Execute();
    }
}
