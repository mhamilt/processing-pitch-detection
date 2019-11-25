class MovingAverageFilter
{
    get currentAverage()
    {
        return this._currentAverage;
    }
    get currentIndex()
    {
        return this._currentIndex;
    }
    get size()
    {
        return this._size;
    }

    set size(value)
    {
        this._size = value;
        this._data = new Array(this._size).fill(0)
    }
    constructor(size)
    {
        this._size = size;
        this._data = new Array(this._size).fill(0)
    }

    getNewAverage(newData)
    {

        let oldData = this._data[this._currentIndex] / this._size;
        this._data[this._currentIndex] = newData / this._size;
        this._currentIndex++;
        this._currentIndex %= this._size;

        this._currentAverage += (newData - oldData);
        return this._currentAverage;
    }
}