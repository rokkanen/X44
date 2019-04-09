namespace Company.Template.Business
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Linq.Expressions;
    using System.Threading.Tasks;

    /// <summary>
    /// Interface for a business service base
    /// </summary>
    /// <typeparam name="T">Type of the entity defined in Domain Model</typeparam>
    /// <typeparam name="K">Type of the entity key</typeparam>
    public interface IServiceAsync<T, K>
    {
        /// <summary>
        /// Get all business entities
        /// </summary>
        /// <returns>Business entity collection</returns>
        Task<IEnumerable<T>> GetAllAsync();

        /// <summary>
        /// Get a business entity by id
        /// </summary>
        /// <param name="id">Business entity key</param>
        /// <returns>Business entity</returns>
        Task<T> GetByIdAsync(K id);

        /// <summary>
        /// Save a business entity
        /// </summary>
        /// <param name="entity">Business entity</param>
        void SaveAsync(T entity);

        /// <summary>
        /// Save a collection of business entities
        /// </summary>
        /// <param name="entities">collection of entities</param>
        void SaveAsync(IEnumerable<T> entities);

        /// <summary>
        /// Delete a business entity with its id
        /// </summary>
        /// <param name="id">Business entity key</param>
        void DeleteAsync(K id);

        /// <summary>
        /// Queries this entity set with Linq.
        /// </summary>
        /// <returns>A list of entities</returns>
        // IQueryable<T> Get();
    }
}
