<?php

namespace HiEvents\DomainObjects;

use Carbon\Carbon;
use HiEvents\DomainObjects\Enums\TicketType;
use HiEvents\DomainObjects\Interfaces\IsSortable;
use HiEvents\DomainObjects\SortingAndFiltering\AllowedSorts;
use Illuminate\Support\Collection;
use LogicException;

class TicketDomainObject extends Generated\TicketDomainObjectAbstract implements IsSortable
{
    private ?Collection $taxAndFees = null;

    private ?Collection $prices = null;

    private ?string $offSaleReason = null;

    private ?string $position = null;

    private ?string $seat_number = null;

    private ?array $taxAndFeeIds = null;

    private ?int $accountId = null;

    private ?string $section = null;

    public static function getDefaultSort(): string
    {
        return self::ORDER;
    }

    public static function getDefaultSortDirection(): string
    {
        return 'asc';
    }

    public static function getAllowedSorts(): AllowedSorts
    {
        return new AllowedSorts(
            [
                self::ORDER => [
                    'asc' => __('Homepage order'),
                ],
                self::CREATED_AT => [
                    'asc' => __('Oldest first'),
                    'desc' => __('Newest first'),
                ],
                self::TITLE => [
                    'asc' => __('Title A-Z'),
                    'desc' => __('Title Z-A'),
                ],
                self::SALE_START_DATE => [
                    'asc' => __('Sale start date closest'),
                    'desc' => __('Sale start date furthest'),
                ],
                self::SALE_END_DATE => [
                    'asc' => __('Sale end date closest'),
                    'desc' => __('Sale end date furthest'),
                ],
            ]
        );
    }

    public function setTaxAndFees(Collection $taxes): TicketDomainObject
    {
        $this->taxAndFees = $taxes;
        return $this;
    }

    public function getTaxRates(): ?Collection
    {
        return $this->getTaxAndFees()?->filter(fn(TaxAndFeesDomainObject $taxAndFee) => $taxAndFee->isTax());
    }

    public function getTaxAndFees(): ?Collection
    {
        return $this->taxAndFees;
    }

    public function getFees(): ?Collection
    {
        return $this->getTaxAndFees()?->filter(fn(TaxAndFeesDomainObject $taxAndFee) => $taxAndFee->isFee());
    }

    public function isSoldOut(): bool
    {
        if (!$this->getTicketPrices() || $this->getTicketPrices()->isEmpty()) {
            return true;
        }

        return $this->getTicketPrices()->every(fn(TicketPriceDomainObject $price) => $price->isSoldOut());
    }

    public function getQuantityAvailable(): int
    {
        if (!$this->getTicketPrices() || $this->getTicketPrices()->isEmpty()) {
            return 0;
        }

        return $this->getTicketPrices()->sum(fn(TicketPriceDomainObject $price) => $price->getQuantityAvailable());
    }

    public function isBeforeSaleStartDate(): bool
    {
        return (!is_null($this->getSaleStartDate())
            && (new Carbon($this->getSaleStartDate()))->isFuture()
        );
    }

    public function isAfterSaleEndDate(): bool
    {
        return (!is_null($this->getSaleEndDate())
            && (new Carbon($this->getSaleEndDate()))->isPast()
        );
    }

    public function isAvailable(): bool
    {
        // If all prices are hidden, it's not available
        if ($this->getType() === TicketType::TIERED->name && $this->getTicketPrices()?->isEmpty()) {
            return false;
        }

        return !$this->isSoldOut()
            && !$this->isBeforeSaleStartDate()
            && !$this->isAfterSaleEndDate()
            && !$this->getIsHidden();
    }

    /**
     * @return Collection<TicketPriceDomainObject>|null
     */
    public function getTicketPrices(): ?Collection
    {
        return $this->prices;
    }

    public function setTicketPrices(?Collection $prices): self
    {
        $this->prices = $prices;

        return $this;
    }

    /**
     * All ticket types except TIERED have a single price, so we can just return the first price.
     *
     * @return float|null
     */
    public function getPrice(): ?float
    {
        if ($this->getType() === TicketType::TIERED->name) {
            throw new LogicException('You cannot get a single price for a tiered ticket. Use getPrices() instead.');
        }

        return $this->getTicketPrices()?->first()->getPrice();
    }

    public function getPriceById(int $priceId): ?TicketPriceDomainObject
    {
        return $this->getTicketPrices()?->first(fn(TicketPriceDomainObject $price) => $price->getId() === $priceId);
    }

    public function isTieredType(): bool
    {
        return $this->getType() === TicketType::TIERED->name;
    }

    public function isDonationType(): bool
    {
        return $this->getType() === TicketType::DONATION->name;
    }

    public function isPaidType(): bool
    {
        return $this->getType() === TicketType::PAID->name;
    }

    public function isFreeType(): bool
    {
        return $this->getType() === TicketType::FREE->name;
    }

    public function getInitialQuantityAvailable(): ?int
    {
        if ($this->getType() === TicketType::TIERED->name) {
            return $this->getTicketPrices()?->sum(fn(TicketPriceDomainObject $price) => $price->getInitialQuantityAvailable());
        }

        return $this->getTicketPrices()?->first()?->getInitialQuantityAvailable();
    }

    public function getQuantitySold(): int
    {
        return $this->getTicketPrices()?->sum(fn(TicketPriceDomainObject $price) => $price->getQuantitySold()) ?? 0;
    }

    public function setOffSaleReason(?string $offSaleReason): TicketDomainObject
    {
        $this->offSaleReason = $offSaleReason;

        return $this;
    }

    public function getOffSaleReason(): ?string
    {
        return $this->offSaleReason;
    }

    public function getPosition(): ?string
    {
        return $this->position;
    }

    public function getSeatNumber(): ?string
    {
        return $this->seat_number;
    }

    public function setPosition(?string $position): self
    {
        $this->position = $position;
        return $this;
    }

    public function setSeatNumber(?string $seatNumber): self
    {
        $this->seat_number = $seatNumber;
        return $this;
    }

    public function setTaxAndFeeIds(?array $taxAndFeeIds): self
    {
        $this->taxAndFeeIds = $taxAndFeeIds;
        return $this;
    }

    public function getTaxAndFeeIds(): ?array
    {
        return $this->taxAndFeeIds;
    }

    public function setAccountId(?int $accountId): self
    {
        $this->accountId = $accountId;
        return $this;
    }

    public function getAccountId(): ?int
    {
        return $this->accountId;
    }

    public function getSection(): ?string
    {
        return $this->section;
    }

    public function setSection(?string $section): self
    {
        $this->section = $section;
        return $this;
    }
}
