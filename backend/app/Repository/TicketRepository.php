<?php

namespace HiEvents\Repository;

use HiEvents\Repository\Eloquent\BaseRepository;
use HiEvents\Repository\Interfaces\TicketRepositoryInterface;
use HiEvents\Http\DTO\QueryParamsDTO;
use Illuminate\Pagination\LengthAwarePaginator;
use App\Models\Ticket;

class TicketRepository extends BaseRepository implements TicketRepositoryInterface 
{
    protected function getModel(): string
    {
        return Ticket::class;
    }

    public function findByEventId(int $eventId, QueryParamsDTO $params): LengthAwarePaginator
    {
        \Log::info('TicketRepository::findByEventId', [
            'eventId' => $eventId,
            'filter_fields' => $params->filter_fields  
        ]);

        $this->model = $this->model->where('event_id', $eventId);

        // Aplicar los filtros manualmente
        if (!empty($params->filter_fields)) {
            foreach ($params->filter_fields as $field => $conditions) {
                foreach ($conditions as $operator => $value) {
                    if ($operator === 'like') {
                        \Log::info('Applying filter', [
                            'field' => $field,
                            'operator' => $operator,
                            'value' => $value
                        ]);
                        $this->model = $this->model->where($field, 'LIKE', '%' . $value . '%');
                    }
                } 
            }
        }

        // Aplicar ordenamiento
        $this->model = $this->model->orderBy($params->sort_by ?? 'id', $params->sort_direction ?? 'asc');

        $query = $this->model->toSql();
        \Log::info('Final query', ['query' => $query]);

        return $this->model->paginate($params->per_page);
    }
}  