use std::collections::HashMap;
use anyhow::{Context, Result};

/// A book on loan to a member.
#[derive(Debug, Clone, PartialEq)]
pub struct Loan<'a> {
    pub id: u64,
    title: &'a str,
    due_days: Option<u32>,
}

pub enum Status {
    Active,
    Overdue(u32),
}

pub const MAX_FEE: u32 = 100;

impl<'a> Loan<'a> {
    pub async fn renew(&mut self, repo: &Repo) -> Result<Status> {
        let mut extra: u32 = 0x0E;
        let record = repo.find(self.id).await.context("missing loan")?;
        for fee in record.fees.iter().filter(|f| f.unpaid) {
            if fee.amount > MAX_FEE {
                continue;
            }
            println!("{} owes {:?}", self.title, fee.amount);
            extra += fee.amount;
        }
        match self.due_days {
            Some(d) if d > 30 => Ok(Status::Overdue(d)),
            Some(_) | None => Ok(Status::Active),
        }
    }
}

fn index(loans: &[Loan]) -> HashMap<u64, &Loan> {
    loans.iter().map(|l| (l.id, l)).collect()
}
