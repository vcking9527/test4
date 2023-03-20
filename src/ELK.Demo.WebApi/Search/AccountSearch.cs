using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using ELK.Demo.WebApi.Dto;
using ELK.Demo.WebApi.Models;
using ELK.Demo.WebApi.Models.Pagination;
using Nest;

namespace ELK.Demo.WebApi.Search
{
    public class AccountSearch : IAccountSearch
    {
        private readonly IElasticClient _client;

        public AccountSearch(IElasticClient client)
        {
            _client = client;
        }

        public async Task<PaginationList<AccountDto>> QueryAsync(AccountQuery query)
        {
            int skip = (query.PageNumber - 1) * query.PageSize; // 計算要跳過多少筆資料

            var searchResponse = await _client.SearchAsync<Account>(s => s
                .From(skip)
                .Size(query.PageSize)
                .Sort(s => s.Ascending("account_number"))
            );
            var countResponse = await _client.CountAsync<AccountDto>();

            List<AccountDto> accounts = searchResponse.Documents
                .Select(d => new AccountDto
                {
                    AccountNumber = d.AccountNumber,
                    Name = $"{d.FirstName} {d.LastName}",
                    Email = d.Email,
                    Balance = d.Balance,
                    Age = d.Age,
                    Gender = d.Gender.Equals("M") ? "Male" : "Female"
                })
                .ToList();

            return new PaginationList<AccountDto>(accounts, countResponse.Count, query.PageNumber, query.PageSize);
        }

        public IEnumerable<Account> GetAccounts()
        {
            var searchResponse = _client.Search<Account>(s => s
                .Query(q => q.MatchAll())
            );

            return searchResponse.Documents;
        }
    }
}