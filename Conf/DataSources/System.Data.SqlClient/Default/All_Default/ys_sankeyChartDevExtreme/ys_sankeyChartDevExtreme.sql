select
    N'Spain' as [source],
    N'United States of America' as [target],
    2 as [weight]
    UNION ALL
select
    N'Germany' as [source],
    N'United States of America' as [target],
    8 as [weight]
    UNION ALL
select
    N'France' as [source],
    N'United States of America' as [target],
    4 as [weight]
    UNION ALL
select
    N'Germany' as [source],
    N'Great Britain' as [target],
    2 as [weight]
    UNION ALL
select
    N'France' as [source],
    N'Great Britain' as [target],
    4 as [weight]
    UNION ALL
select
    N'United States of America' as [source],
    N'Australia' as [target],
    6 as [weight]
    UNION ALL
select
    N'United States of America' as [source],
    N'New Zealand' as [target],
    5 as [weight]
    UNION ALL
select
    N'United States of America' as [source],
    N'Japan' as [target],
    3 as [weight]
    UNION ALL
select
    N'Great Britain' as [source],
    N'New Zealand' as [target],
    4 as [weight]
    UNION ALL
select
    N'Great Britain' as [source],
    N'Japan' as [target],
    1 as [weight]

 /* 
    { source: 'Spain', target: 'United States of America', weight: 2 },
    { source: 'Germany', target: 'United States of America', weight: 8 },
    { source: 'France', target: 'United States of America', weight: 4 },
    { source: 'Germany', target: 'Great Britain', weight: 2 },
    { source: 'France', target: 'Great Britain', weight: 4 },
    { source: 'United States of America', target: 'Australia', weight: 6 },
    { source: 'United States of America', target: 'New Zealand', weight: 5 },
    { source: 'United States of America', target: 'Japan', weight: 3 },
    { source: 'Great Britain', target: 'New Zealand', weight: 4 },
    { source: 'Great Britain', target: 'Japan', weight: 1 }
  */