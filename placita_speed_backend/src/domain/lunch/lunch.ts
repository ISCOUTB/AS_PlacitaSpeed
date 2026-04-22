import { Ticket } from '../ticket/ticket'

export class Lunch {
    id: number;
    name: string;
    description: string;
    virtual_price: number;
    stock: number;
    tickets: Ticket[];

    public constructor(
        id: number,
        name: string,
        description: string,
        virtual_price: number,
        stock: number,
        tickets: Ticket[]
    ) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.virtual_price = virtual_price;
        this.stock = stock;
        this.tickets = tickets;
    }
}