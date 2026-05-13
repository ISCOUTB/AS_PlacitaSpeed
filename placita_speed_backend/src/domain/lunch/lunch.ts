export class Lunch {
    id: number;
    name: string;
    description: string;
    virtual_price: number;
    stock: number;

    public constructor(
        id: number,
        name: string,
        description: string,
        virtual_price: number,
        stock: number,
    ) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.virtual_price = virtual_price;
        this.stock = stock;
    }
}