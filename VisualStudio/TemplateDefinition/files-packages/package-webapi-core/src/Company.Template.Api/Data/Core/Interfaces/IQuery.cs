namespace Company.Template.Data
{
	using System.Collections.Generic;
	
     public interface IQuery<TItem>
    {
        TItem Result { get; }
        bool Ok { get; }
        void Execute();
    }
}
