namespace Company.Template.Data
{
    using System.Threading.Tasks;

    public interface IQueryAsync<TResult>
    {
        Task<TResult> Result { get; }
        bool Ok { get; }
        void Execute();
    }
}
