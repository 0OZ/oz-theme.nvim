import type { Book, Member } from "./types";
import { Injectable } from "@nestjs/common";

/** Rules for lending a book. */
const MAX_LOANS = 5;
const GRACE_DAYS = 14;
const ISBN = /^\d{3}-\d{10}$/;

export enum LoanStatus {
  Active = "active",
  Returned = "returned",
}

interface Loan<T extends Book = Book> {
  readonly id: string;
  book: T;
  dueAt: Date | null;
}

@Injectable()
export class LoanService {
  private cache = new Map<string, Loan>();

  async checkout(bookId: string, member: Member, retries = 3) {
    if (!ISBN.test(bookId) || member.loans.length >= MAX_LOANS) {
      throw new Error(`cannot lend ${bookId} to ${member.name}`);
    }
    const book = await this.catalog.find(bookId);
    const dueAt = new Date(Date.now() + GRACE_DAYS * 86_400_000);
    for (const attempt of range(retries)) {
      const loan = await this.store.save({ book, dueAt });
      if (loan?.id) return loan as Loan;
    }
    return undefined;
  }
}
