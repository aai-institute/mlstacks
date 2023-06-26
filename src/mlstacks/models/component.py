"""Component model."""

from typing import Dict, Optional

from pydantic import BaseModel


class ComponentMetadata(BaseModel):
    """Component metadata model.

    Attributes:
        region: The region where the component will be deployed.
        config: The configuration for the component.
        tags: The tags for the component.
        environment_variables: The environment variables for the component.
    """

    region: str
    config: Optional[Dict[str, str]]
    tags: Optional[Dict[str, str]]
    environment_variables: Optional[Dict[str, str]]


class Component(BaseModel):
    """Component model.

    Attributes:
        spec_version: The version of the component spec.
        spec_type: The type of the component spec.
        component_type: The type of the component.
        name: The name of the component.
        provider: The provider of the component.
        metadata: The metadata of the component.
    """

    spec_version: int = 1
    spec_type: str = "component"
    component_type: str
    name: str
    provider: str
    metadata: ComponentMetadata
